<?php

	//////////////////////////////////////////////////////////////////////////////////////////

	if (!defined('GAUSS_CMS'))
	{
		echo basename(__FILE__);
		exit;
	}

	//////////////////////////////////////////////////////////////////////////////////////////

	if (!trait_exists('basic'))
	{
		require(CLASSES_DIR . DS . 'trait.basic.php');
	}
	if (!trait_exists('db_connect'))
	{
		require(CLASSES_DIR . DS . 'trait.db_connect.php');
	}

	//////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * Class images
	 */
	class images
	{
		/**
		 *
		 */
		const IMAGES_CONVERT_EXT = 'png';
		/**
		 *
		 */
		const PNG_COMPRESS_LEVEL = 1;
		/**
		 *
		 */
		const JPEG_QUALITY_LEVEL = 95;
		/**
		 *
		 */
		const PNG_QUALITY_LEVEL = 50;

		use basic, db_connect;

		/**
		 * @param $file
		 * @param $config
		 * @return array
		 */
		static public final function _upload_process($file, $config)
		{
			$cms_config = config::get();

			foreach (array('upload.image.compress', 'upload.image.mini', 'upload.image.watermark', 'upload.image.mini.proportion', 'upload.image.compress.x', 'upload.image.compress.y', 'upload.image.mini.x', 'upload.image.mini.y',) as $key)
			{
				if (!isset($config[$key]))
				{
					self::err('' . __CLASS__ . '::' . __METHOD__ . ' >> $config[\'' . $key . '\'] not exist!');
				}
				$config[$key] = self::integer(!isset($config[$key]) ? $config[$key] : $config[$key]);
			}

			$file = self::any2any($file, $config);

			if ($config['upload.image.compress'])
			{
				self::compress($file['filename'], $config['upload.image.compress.x'], $config['upload.image.compress.y']);
			}

			if ($config['upload.image.mini'])
			{
				$file['mini'] = self::makemini($file['filename'], $config['upload.image.mini.x'], $config['upload.image.mini.y'], $config['upload.image.mini.proportion']);
			}
			else
			{
				$file['mini'] = false;
			}

			if ($config['upload.image.watermark'] && file_exists(UPL_DIR . DS . 'watermak.png'))
			{
				self::watermark($file['filename']);
			}

			$file['size'] = filesize($file['filename']);
			$file['md5']  = self::md5_file($file['filename']);

            if( self::IMAGES_CONVERT_EXT == 'png' )
            {
                self::png_optimize_using_pngquant( $file['filename'] );
            }

			self::ins2db($file);

			return $file;
		}

		/**
		 * @param bool $hash
		 * @return bool
		 */
		static public final function del($hash = false)
		{
			if (!$hash)
			{
				return false;
			}

			$SQL = 'SELECT * FROM images WHERE md5=\'' . self::strtolower(self::filter($hash)) . '\';';
			$_cl = new images;
			$image = $_cl->db->super_query($SQL);

			if (!$image || !is_array($image) || !isset($image['serv_name']))
			{
				return false;
			}

			$url = UPL_DIR . DS . 'images' . DS . date('Y-m-d', strtotime($image['load_time'])) . DS . $image['serv_name'];
			$mini_url = UPL_DIR . DS . 'images' . DS . date('Y-m-d', strtotime($image['load_time'])) . DS . 'mini' . DS . $image['serv_name'];

			if (file_exists($url))
			{
				unlink($url);
			}
			if (file_exists($mini_url))
			{
				unlink($mini_url);
			}

			$SQL = 'DELETE FROM images WHERE md5=\'' . $image['md5'] . '\';';
			$image = $_cl->db->query($SQL);
			$_cl->db->free();
			return true;
		}

		/**
		 * @param bool $data
		 * @return array|bool|int
		 */
		static private final function get_image_type($data = false)
		{
			if (!is_scalar($data) && !is_array($data))
			{
				self::err('' . __CLASS__ . '::' . __METHOD__ . ' accepts string or array only!');
			}
			if (is_array($data))
			{
				return array_map('self::' . __METHOD__, $data);
			}

			if (!file_exists($data))
			{
				self::err('' . __CLASS__ . '::' . __METHOD__ . ' >> file not exist!');
			}

			$data = self::strtolower(self::fileinfo($data));

			if (strpos($data, 'image') === false)
			{
				return false;
			}
			if (strpos($data, 'png') !== false)
			{
				return IMAGETYPE_PNG;
			}
			if (strpos($data, 'jpeg') !== false)
			{
				return IMAGETYPE_JPEG;
			}
			if (strpos($data, 'gif') !== false)
			{
				return IMAGETYPE_GIF;
			}
			return false;
			// exif_imagetype($file)
		}

		/**
		 * @param array $file
		 * @param array $config
		 * @return array
		 */
		static private final function any2any($file, $config = array())
		{
			$im = false;

			switch (self::get_image_type($file['filename']))
			{
				case IMAGETYPE_GIF:
					$im = imagecreatefromgif($file['filename']);
					break;
				case IMAGETYPE_JPEG:
					$im = imagecreatefromjpeg($file['filename']);
					break;
				case IMAGETYPE_PNG:
					$im = imagecreatefrompng($file['filename']);
					break;
			}

			if ($im === false)
			{
				$file['status'] = 0;
				$file['error'] = 'Помилка обробки зображення!';
				unlink($file['filename']);
				return $file;
			}

			$_dir = dirname($file['filename']);
			$_fnm = preg_replace('!\.(\w+?)$!i', '.' . self::IMAGES_CONVERT_EXT, basename($file['filename']));
			$_newfile = $_dir . DS . $_fnm;

			if (self::IMAGES_CONVERT_EXT == 'png')
			{
				imagepng($im, $_newfile, self::PNG_COMPRESS_LEVEL);
                //self::png_optimize_using_pngquant( $_newfile );
			}
			if (self::IMAGES_CONVERT_EXT == 'jpeg')
			{
				imagejpeg($im, $_newfile, self::JPEG_QUALITY_LEVEL);
			}

			if ($_newfile != $file['filename'])
			{
				unlink($file['filename']);
			}

			$file['filename'] = $_newfile;
			$file['ext'] = self::IMAGES_CONVERT_EXT;
			$file['type'] = self::fileinfo($file['filename']);
			$file['size'] = filesize($file['filename']);
			$file['name'] = basename($file['filename']);

			return $file;
		}

		/**
		 * @param $file
		 * @return array|bool
		 */
		static private final function watermark($file)
		{
			$wm = imagecreatefrompng(UPL_DIR . DS . 'watermak.png');

			if (self::IMAGES_CONVERT_EXT == 'png')
			{
				$im = imagecreatefrompng($file);
			}
			if (self::IMAGES_CONVERT_EXT == 'jpeg')
			{
				$im = imagecreatefromjpeg($file);
			}

			$wm_s = array('w' => imagesx($wm), 'h' => imagesy($wm));
			$im_s = array('w' => imagesx($im), 'h' => imagesy($im));

			if ($wm_s['w'] >= $im_s['w'] || $wm_s['h'] >= $im_s['h'])
			{
				return false;
			}

			imagecopy($im, $wm, rand($wm_s['w'], $im_s['w'] - $wm_s['w']), rand($wm_s['h'], $im_s['h'] - $wm_s['h']), 0, 0, $wm_s['w'], $wm_s['h']);
			imagedestroy($wm);

			if (self::IMAGES_CONVERT_EXT == 'png')
			{
				imagepng($im, $file, self::PNG_COMPRESS_LEVEL);
			}
			if (self::IMAGES_CONVERT_EXT == 'jpeg')
			{
				imagejpeg($im, $file, self::JPEG_QUALITY_LEVEL);
			}
			return true;
		}

		/**
		 * @param      $file
		 * @param int  $x
		 * @param int  $y
		 * @param bool $prop
		 * @return string
		 */
		static private final function makemini($file, $x = 200, $y = 100, $prop = false)
		{
			if (self::IMAGES_CONVERT_EXT == 'png')
			{
				$im = imagecreatefrompng($file);
			}
			if (self::IMAGES_CONVERT_EXT == 'jpeg')
			{
				$im = imagecreatefromjpeg($file);
			}

			$sizes = array();
			$sizes['old'] = array();
			$sizes['old']['w'] = imagesx($im);
			$sizes['old']['h'] = imagesy($im);
			$sizes['new'] = array();
			$sizes['new']['w'] = $x;
			$sizes['new']['h'] = $y;

			if ($prop)
			{
				$koef = $sizes['old']['w'] / $sizes['old']['h'];

				if ($x && $y)
				{
					if ($sizes['old']['w'] >= $sizes['old']['h'])
					{
						$sizes['new']['h'] = ceil($sizes['new']['w'] / $koef);
					}

					if ($sizes['old']['h'] >= $sizes['old']['w'])
					{
						$sizes['new']['w'] = ceil($sizes['new']['h'] * $koef);
					}
				}

				if (!$x && $y)
				{
					$sizes['new']['w'] = ceil($sizes['new']['h'] * $koef);
				}
				if ($x && !$y)
				{
					$sizes['new']['h'] = ceil($sizes['new']['w'] / $koef);
				}
			}
			else
			{
				if (!$sizes['new']['w'] || !$sizes['new']['h'])
				{
					return false;
				}
			}

			$sizes['copy'] = array();
			$sizes['copy']['w'] = array();
			$sizes['copy']['w']['from'] = 0;
			$sizes['copy']['w']['to'] = 0;
			$sizes['copy']['h'] = array();
			$sizes['copy']['h']['from'] = 0;
			$sizes['copy']['h']['to'] = 0;

			$koef = $sizes['new']['w'] / $sizes['new']['h'];

			if (($sizes['old']['w'] / $sizes['old']['h']) >= $koef)
			{
				$sizes['copy']['h']['from'] = 0;
				$sizes['copy']['h']['to'] = $sizes['old']['h'];

				$sizes['copy']['w']['to'] = $sizes['copy']['h']['to'] * $koef;
				$sizes['copy']['w']['from'] = $sizes['old']['w'] / 2 - $sizes['copy']['w']['to'] / 2;
				if ($sizes['copy']['w']['from'] < 0)
				{
					$sizes['copy']['w']['from'] = 0;
				}
			}
			else
			{
				$sizes['copy']['w']['from'] = 0;
				$sizes['copy']['w']['to'] = $sizes['old']['w'];

				$sizes['copy']['h']['to'] = $sizes['copy']['w']['to'] / $koef;
				$sizes['copy']['h']['from'] = $sizes['old']['h'] / 2 - $sizes['copy']['h']['to'] / 2;
				if ($sizes['copy']['h']['from'] < 0)
				{
					$sizes['copy']['h']['from'] = 0;
				}
			}

			$new_im = imagecreatetruecolor($sizes['new']['w'], $sizes['new']['h']);

			imagecopyresized($new_im, $im, 0, 0, $sizes['copy']['w']['from'], $sizes['copy']['h']['from'], $sizes['new']['w'], $sizes['new']['h'], $sizes['copy']['w']['to'], $sizes['copy']['h']['to']);
			imagedestroy($im);

			$file = dirname($file) . DS . 'mini' . DS . basename($file);

			if (self::IMAGES_CONVERT_EXT == 'png')
			{
				imagepng($new_im, $file, self::PNG_COMPRESS_LEVEL);
                self::png_optimize_using_pngquant( $file );
			}
			if (self::IMAGES_CONVERT_EXT == 'jpeg')
			{
				imagejpeg($new_im, $file, self::JPEG_QUALITY_LEVEL);
			}
			return $file;
		}

		/**
		 * @param $file
		 * @param $x
		 * @param $y
		 * @return bool
		 */
		static private final function compress($file, $x, $y)
		{
			if (!$x && !$y)
			{
				return false;
			}

			if (self::IMAGES_CONVERT_EXT == 'png')
			{
				$im = imagecreatefrompng($file);
			}
			if (self::IMAGES_CONVERT_EXT == 'jpeg')
			{
				$im = imagecreatefromjpeg($file);
			}

			$sizes = array();
			$sizes['old'] = array();
			$sizes['old']['w'] = imagesx($im);
			$sizes['old']['h'] = imagesy($im);
			$sizes['new'] = array();
			$sizes['new']['w'] = $x;
			$sizes['new']['h'] = $y;

			if ($sizes['new']['h'] == 0)
			{
				$sizes['new']['h'] = $sizes['old']['h'] * 1000000;
			}
			if ($sizes['new']['w'] == 0)
			{
				$sizes['new']['w'] = $sizes['old']['w'] * 1000000;
			}

			if ($sizes['old']['w'] <= $sizes['new']['w'] && $sizes['old']['h'] <= $sizes['new']['h'])
			{
				imagedestroy($im);
				return false;
			}

			$koef = ($sizes['old']['w']) / ($sizes['old']['h']);

			if ($x && $y)
			{
				if ($sizes['old']['w'] >= $sizes['old']['h'])
				{
					$sizes['new']['h'] = ceil($sizes['new']['w'] / $koef);
				}

				if ($sizes['old']['h'] >= $sizes['old']['w'])
				{
					$sizes['new']['w'] = ceil($sizes['new']['h'] * $koef);
				}
			}

			if (!$x && $y)
			{
				$sizes['new']['w'] = ceil($sizes['new']['h'] * $koef);
			}

			if ($x && !$y)
			{
				$sizes['new']['h'] = ceil($sizes['new']['w'] / $koef);
			}

			$sizes['new']['w'] = self::integer($sizes['new']['w']);
			$sizes['new']['h'] = self::integer($sizes['new']['h']);

			$new_im = imagecreatetruecolor($sizes['new']['w'], $sizes['new']['h']);

			imagecopyresized($new_im, $im, 0, 0, 0, 0, $sizes['new']['w'], $sizes['new']['h'], $sizes['old']['w'], $sizes['old']['h']);
			imagedestroy($im);

			if (self::IMAGES_CONVERT_EXT == 'png')
			{
				imagepng($new_im, $file, self::PNG_COMPRESS_LEVEL);
			}
			if (self::IMAGES_CONVERT_EXT == 'jpeg')
			{
				imagejpeg($new_im, $file, self::JPEG_QUALITY_LEVEL);
			}
			return true;
		}

		/**
		 * @param $data
		 * @return bool
		 */
		static private final function ins2db($data)
		{
			$_cl = new images;

			$_2db = array();
			$_2db['post_id'] = isset($data['post_id']) ? self::integer($data['post_id']) : 0;
			$_2db['md5'] = $_cl->db->safesql(isset($data['md5']) ? self::filter($data['md5']) : 0);
			$_2db['user_id'] = CURRENT_USER_ID;
			$_2db['serv_name'] = $_cl->db->safesql(basename($data['filename']));
			$_2db['load_time'] = date('Y-m-d H:i:s');
			$_2db['is_mini'] = $data['mini'] ? 1 : 0;

			if (!file_exists($data['filename']))
			{
				return false;
			}

			$SQL = 'SELECT COUNT(md5) as count FROM images WHERE md5=\'' . $_2db['md5'] . '\';';
			if ($_cl->db->get_count($SQL))
			{
				// unlink($data['filename']);
				return false;
			}

			$SQL = 'INSERT INTO images ("' . implode('", "', array_keys($_2db)) . '") VALUES (\'' . implode('\', \'', array_values($_2db)) . '\');';
			$_cl->db->query($SQL);
			$_cl->db->free();
			$_cl = false;
			return true;
		}

        static public final function png_optimize_using_pngquant( $filename )
        {
            if( self::IMAGES_CONVERT_EXT != 'png' ){ return $filename; }
            if( !file_exists( $filename ) ){ return false; }

            $max_quality = self::PNG_QUALITY_LEVEL;
            $min_quality = $max_quality - round( $max_quality / 2 );

            $compressed_png_content = false;
            $_filename = escapeshellarg( $filename );

            $cmd = array();
            $cmd[] = '/usr/bin/pngquant -f --speed 1 --iebug --quality='.$min_quality.'-'.$max_quality.' --output '.$_filename.' '.$_filename;

            $disabled = explode(',', ini_get('disable_functions'));
            if( function_exists('shell_exec') && !in_array('shell_exec', $disabled) )
            {
                foreach( $cmd as $c )
                {
                    shell_exec( $c );
                }
            }
            return $filename;
        }

		/**
		 * @param int $post_id
		 * @return bool
		 */
		static public final function update($post_id = 0)
		{
			$post_id = self::integer($post_id);
			$_cl = new images;
			$SQL = 'UPDATE images SET post_id=' . $post_id . ' WHERE post_id=0;';
			$_cl->db->query($SQL);
			$_cl->db->free();
			$_cl = false;
			return true;
		}

		/**
		 * @param int $post_id
		 * @return array
		 */
		static public final function get($post_id = 0)
		{
			$post_id = self::integer($post_id);
			$_cl = new images;
			$SQL = 'SELECT * FROM images WHERE post_id=' . $post_id . ' ORDER BY load_time DESC;';
			$SQL = $_cl->db->query($SQL);

			$images = array();
			while (($row = $_cl->db->get_row($SQL)) !== false)
			{
				$images[] = $row;
			}

			$_cl->db->free();
			$_cl = false;

			return $images;
		}

	}

?>